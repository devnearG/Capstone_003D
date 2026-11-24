"""Phase-3 integration sanity: boots uvicorn, exercises the new endpoints,
restores seeded state, and tears the server down. Run with the backend venv:
    .venv/Scripts/python scripts_integration_phase3.py
"""
import json
import re
import os
import subprocess
import sys
import time
import urllib.request
import urllib.error
import uuid
from pathlib import Path

from sqlalchemy import create_engine, text

from app.core.config import settings

PORT = int(os.getenv("PHASE3_PORT", "8001"))
BASE = f"http://localhost:{PORT}"
API = f"{BASE}/api/v1"
ROOT = Path(__file__).parent
LOG = ROOT / "_uvicorn_phase3.log"

RESULTS: list[tuple[str, bool, str]] = []


def check(name: str, ok: bool, detail: str = "") -> None:
    RESULTS.append((name, ok, detail))
    print(f"{'PASS' if ok else 'FAIL'}  {name}  {detail}")


def req(method: str, path: str, token: str | None = None, body: dict | None = None,
        raw: bytes | None = None, headers: dict | None = None) -> tuple[int, object]:
    url = f"{API}{path}"
    data = raw
    hdrs = {"Accept-Language": "es"}
    if body is not None:
        data = json.dumps(body).encode()
        hdrs["Content-Type"] = "application/json"
    if token:
        hdrs["Authorization"] = f"Bearer {token}"
    if headers:
        hdrs.update(headers)
    r = urllib.request.Request(url, data=data, method=method, headers=hdrs)
    try:
        with urllib.request.urlopen(r) as resp:
            payload = resp.read()
            return resp.status, (json.loads(payload) if payload else None)
    except urllib.error.HTTPError as e:
        payload = e.read()
        try:
            return e.code, json.loads(payload)
        except Exception:
            return e.code, payload


def magic_token(email: str) -> str:
    req("POST", "/auth/magic-link", body={"email": email, "locale": "es"})
    time.sleep(0.6)
    text = LOG.read_text(encoding="utf-8", errors="replace")
    tokens = re.findall(r"/auth/verify\?token=([A-Za-z0-9_\-]+)", text)
    assert tokens, "no magic-link token found in uvicorn log"
    return tokens[-1]


def login(email: str) -> str:
    status, data = req("POST", "/auth/verify", body={"token": magic_token(email)})
    assert status == 200, f"verify failed: {data}"
    return data["access_token"]  # type: ignore[index]


def delegation_token() -> str:
    text = LOG.read_text(encoding="utf-8", errors="replace")
    tokens = re.findall(r"/delegate/([A-Za-z0-9_\-]+)", text)
    assert tokens, "no delegation token found in uvicorn log"
    return tokens[-1]


def invitation_token() -> str:
    text = LOG.read_text(encoding="utf-8", errors="replace")
    tokens = re.findall(r"/invite/([A-Za-z0-9_\-]+)", text)
    assert tokens, "no invitation token found in uvicorn log"
    return tokens[-1]


def tiny_png() -> bytes:
    # 1x1 transparent PNG
    return bytes.fromhex(
        "89504e470d0a1a0a0000000d494844520000000100000001080600000"
        "01f15c4890000000d4944415478da63fcffff3f030005fe02fea72d99"
        "340000000049454e44ae426082"
    )


def seed_integration_fixtures() -> None:
    """Insert the client, consultant and distributor fixtures in the configured DB."""
    engine = create_engine(settings.sync_database_url)
    with engine.begin() as connection:
        org_id = connection.execute(
            text("SELECT id FROM organizations WHERE name='Acme Industrial' LIMIT 1")
        ).scalar_one_or_none()
        if org_id is None:
            org_id = str(uuid.uuid4())
            connection.execute(
                text(
                    "INSERT INTO organizations "
                    "(id, name, sector, size, country, currency, doc_locale, theme, plan) "
                    "VALUES (:id, 'Acme Industrial', 'Manufacturing', '51-250', 'United Kingdom', 'GBP', 'es', 'light', 'free')"
                ),
                {"id": org_id},
            )

        client_id = connection.execute(
            text("SELECT id FROM users WHERE email='smoke2@acme-industrial.co.uk' LIMIT 1")
        ).scalar_one_or_none()
        if client_id is None:
            client_id = str(uuid.uuid4())
            connection.execute(
                text(
                    "INSERT INTO users "
                    "(id, email, full_name, role, locale, status, organization_id) "
                    "VALUES (:id, 'smoke2@acme-industrial.co.uk', 'Smoke Client', 'client', 'es', 'active', :org_id)"
                ),
                {"id": client_id, "org_id": org_id},
            )
        else:
            connection.execute(
                text("UPDATE users SET organization_id=:org_id, status='active' WHERE id=:id"),
                {"id": client_id, "org_id": org_id},
            )

        assessment_id = connection.execute(
            text("SELECT id FROM assessments WHERE organization_id=:org_id LIMIT 1"),
            {"org_id": org_id},
        ).scalar_one_or_none()
        if assessment_id is None:
            connection.execute(
                text(
                    "INSERT INTO assessments (id, organization_id, status, plan, started_at) "
                    "VALUES (:id, :org_id, 'in_progress', 'free', CURRENT_TIMESTAMP)"
                ),
                {"id": str(uuid.uuid4()), "org_id": org_id},
            )

        member_exists = connection.execute(
            text("SELECT 1 FROM org_members WHERE organization_id=:org_id AND user_id=:user_id LIMIT 1"),
            {"org_id": org_id, "user_id": client_id},
        ).scalar_one_or_none()
        if member_exists is None:
            connection.execute(
                text(
                    "INSERT INTO org_members (id, organization_id, user_id, role, status) "
                    "VALUES (:id, :org_id, :user_id, 'admin', 'active')"
                ),
                {"id": str(uuid.uuid4()), "org_id": org_id, "user_id": client_id},
            )

        connection.execute(
            text(
                "INSERT INTO users (id, email, full_name, role, locale, status) "
                "VALUES (:id, :email, :full_name, 'consultant', 'es', 'active') "
                "ON CONFLICT (email) DO NOTHING"
            ),
            {
                "id": str(uuid.uuid4()),
                "email": "consultant.phase3@tryaigap.dev",
                "full_name": "Consultant P3",
            },
        )
        connection.execute(
            text(
                "INSERT INTO users (id, email, full_name, role, locale, status, organization_id) "
                "VALUES (:id, :email, 'Admin P3', 'admin', 'es', 'active', :org_id) "
                "ON CONFLICT (email) DO UPDATE SET role='admin', status='active', organization_id=:org_id"
            ),
            {
                "id": str(uuid.uuid4()),
                "email": "admin.phase3@tryaigap.dev",
                "org_id": org_id,
            },
        )
        connection.execute(
            text(
                "UPDATE organizations SET plan='free' WHERE id=:org_id"
            ),
            {"org_id": org_id},
        )
        connection.execute(
            text("UPDATE assessments SET plan='free' WHERE organization_id=:org_id"),
            {"org_id": org_id},
        )
        connection.execute(
            text(
                "UPDATE users SET role='client', status='active' "
                "WHERE email='smoke2@acme-industrial.co.uk'"
            )
        )
        connection.execute(
            text(
                "DELETE FROM consultant_assignments WHERE organization_id=:org_id "
                "AND consultant_id IN (SELECT id FROM users WHERE email='consultant.phase3@tryaigap.dev')"
            ),
            {"org_id": org_id},
        )
        connection.execute(
            text(
                "DELETE FROM consultant_assignments WHERE assigned_by IN "
                "(SELECT id FROM users WHERE email='admin.phase3@tryaigap.dev')"
            )
        )
        connection.execute(
            text(
                "DELETE FROM org_members WHERE user_id IN "
                "(SELECT id FROM users WHERE email='lider.ventas@acme-industrial.co.uk')"
            )
        )
        connection.execute(
            text("DELETE FROM users WHERE email='lider.ventas@acme-industrial.co.uk'")
        )
        connection.execute(
            text(
                "INSERT INTO distributor_codes (id, code, discount_pct, active) "
                "VALUES (:id, 'TESTPARTNER', 10, true) "
                "ON CONFLICT (code) DO NOTHING"
            ),
            {"id": str(uuid.uuid4())},
        )


def restore_integration_fixtures() -> None:
    """Restore the seed state after the integration run."""
    engine = create_engine(settings.sync_database_url)
    with engine.begin() as connection:
        connection.execute(text("UPDATE organizations SET plan='free' WHERE name='Acme Industrial'"))
        connection.execute(
            text(
                "UPDATE users SET role='client', status='active' "
                "WHERE email='smoke2@acme-industrial.co.uk'"
            )
        )
        connection.execute(
            text(
                "UPDATE assessments SET plan='free' WHERE organization_id IN "
                "(SELECT id FROM organizations WHERE name='Acme Industrial')"
            )
        )
        connection.execute(text("DELETE FROM users WHERE email='consultant.phase3@tryaigap.dev'"))
        connection.execute(
            text(
                "DELETE FROM org_members WHERE user_id IN "
                "(SELECT id FROM users WHERE email='lider.ventas@acme-industrial.co.uk')"
            )
        )
        connection.execute(
            text("DELETE FROM users WHERE email='lider.ventas@acme-industrial.co.uk'")
        )
        connection.execute(
            text(
                "DELETE FROM consultant_assignments WHERE assigned_by IN "
                "(SELECT id FROM users WHERE email='admin.phase3@tryaigap.dev')"
            )
        )
        connection.execute(text("DELETE FROM users WHERE email='admin.phase3@tryaigap.dev'"))
        connection.execute(text("DELETE FROM distributor_codes WHERE code='TESTPARTNER'"))


def main() -> int:
    # Pre-seed: consultant user + distributor code in the configured database.
    seed_integration_fixtures()

    proc = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "app.main:app", "--port", str(PORT)],
        cwd=ROOT, stdout=LOG.open("w", encoding="utf-8"), stderr=subprocess.STDOUT,
    )
    try:
        for _ in range(60):
            try:
                with urllib.request.urlopen(f"{BASE}/health", timeout=1):
                    break
            except Exception:
                time.sleep(0.5)
        else:
            print("server did not start")
            return 1

        token = login("smoke2@acme-industrial.co.uk")
        admin_token = login("admin.phase3@tryaigap.dev")

        # --- admin catalog and mutations ---
        status, admin_orgs = req("GET", "/admin/organizations", admin_token)
        check(
            "admin organizations",
            status == 200 and isinstance(admin_orgs, list)
            and all("progress" in org and "maturity_score" in org for org in admin_orgs),
            f"status={status}",
        )
        status, admin_users = req("GET", "/admin/users", admin_token)
        check("admin users", status == 200 and isinstance(admin_users, list), f"status={status}")
        status, admin_consultants = req("GET", "/admin/consultants", admin_token)
        check("admin consultants", status == 200 and isinstance(admin_consultants, list), f"status={status}")
        status, _ = req("GET", "/admin/audit", admin_token)
        check("admin audit", status == 200, f"status={status}")
        org_id = next(item["id"] for item in admin_orgs if item["name"] == "Acme Industrial")
        client_id = next(
            item["id"] for item in admin_users
            if item["email"] == "smoke2@acme-industrial.co.uk"
        )
        consultant_id = next(
            item["id"] for item in admin_consultants
            if item["email"] == "consultant.phase3@tryaigap.dev"
        )
        status, _ = req("PATCH", f"/admin/organizations/{org_id}/plan", admin_token,
                        body={"plan": "pro"})
        check("admin update organization plan", status == 200, f"status={status}")
        status, _ = req("PATCH", f"/admin/users/{client_id}/role", admin_token,
                        body={"role": "consultant"})
        check("admin update user role", status == 200, f"status={status}")
        status, _ = req("PATCH", f"/admin/users/{client_id}/status", admin_token,
                        body={"status": "disabled"})
        check("admin disable user", status == 200, f"status={status}")
        status, _ = req("PATCH", f"/admin/users/{client_id}/status", admin_token,
                        body={"status": "active"})
        check("admin reactivate user", status == 200, f"status={status}")
        status, assignment = req("POST", "/admin/consultant-assignments", admin_token,
                                 body={"organization_id": org_id, "consultant_id": consultant_id})
        check("admin assign consultant", status == 201, f"status={status}")
        assignment_id = assignment["id"] if isinstance(assignment, dict) else None

        # --- assessment ---
        status, assessment = req("GET", "/assessments/current", token)
        check("GET /assessments/current", status == 200, f"plan={assessment.get('plan') if isinstance(assessment, dict) else '?'}")
        aid = assessment["id"]  # type: ignore[index]

        # --- documents ---
        boundary = "----p3boundary"
        parts = []
        for name, value in [("assessment_id", aid), ("area_key", "ventas")]:
            parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode())
        parts.append(
            f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="evidence.png"\r\n'
            f"Content-Type: image/png\r\n\r\n".encode() + tiny_png() + b"\r\n"
        )
        parts.append(f"--{boundary}--\r\n".encode())
        status, doc = req("POST", "/documents", token, raw=b"".join(parts),
                          headers={"Content-Type": f"multipart/form-data; boundary={boundary}"})
        check("POST /documents (multipart)", status == 201, f"status={status}")
        doc_id = doc["id"] if isinstance(doc, dict) else None  # type: ignore[index]

        status, page = req("GET", f"/documents?assessment_id={aid}&area_key=ventas", token)
        item = page["items"][0] if isinstance(page, dict) and page["items"] else {}  # type: ignore[index]
        check("GET /documents (filter + extended fields)", status == 200 and item.get("area_key") == "ventas",
              f"items={page.get('meta', {}).get('total') if isinstance(page, dict) else '?'}")

        # download (binary)
        r = urllib.request.Request(f"{API}/documents/{doc_id}/download",
                                   headers={"Authorization": f"Bearer {token}"})
        try:
            with urllib.request.urlopen(r) as resp:
                blob = resp.read()
                check("GET /documents/{id}/download", resp.status == 200 and blob == tiny_png(),
                      f"{len(blob)} bytes")
        except urllib.error.HTTPError as e:
            check("GET /documents/{id}/download", False, f"HTTP {e.code}")

        status, _ = req("DELETE", f"/documents/{doc_id}", token)
        check("DELETE /documents/{id}", status == 204, f"status={status}")

        # --- team / invitations ---
        status, _inv = req("POST", "/invitations", token, body={
            "full_name": "Lider Ventas", "email": "lider.ventas@acme-industrial.co.uk",
            "area_key": "ventas", "whatsapp": "+56912345678"})
        check("POST /invitations", status == 201, f"status={status}")
        inv_id = _inv["invitation_id"] if isinstance(_inv, dict) else None  # type: ignore[index]

        status, team = req("GET", "/team", token)
        invs = team.get("invitations", []) if isinstance(team, dict) else []
        check("GET /team (members + invitations)", status == 200 and any(
            i["invitation_id"] == inv_id for i in invs), f"invitations={len(invs)}")

        status, _ = req("POST", f"/invitations/{inv_id}/resend", token)
        check("POST /invitations/{id}/resend", status == 200, f"status={status}")
        invite_token = invitation_token()
        status, info = req("GET", f"/invitations/info/{invite_token}")
        check("GET /invitations/info/{token}", status == 200 and info.get("status") == "sent", "")
        status, accepted = req(
            "POST",
            f"/invitations/info/{invite_token}/accept",
            body={"full_name": "Lider Ventas"},
        )
        check(
            "POST /invitations/info/{token}/accept",
            status == 200 and accepted.get("user", {}).get("organization", {}).get("id") == org_id,
            f"status={status}",
        )
        status, _ = req("DELETE", f"/invitations/{inv_id}", token)
        check("DELETE /invitations/{id}", status == 204, f"status={status}")

        # --- delegation (public page endpoints) ---
        status, q = req("GET", "/questionnaires?module=maturity&locale=es", token)
        qid = q["blocks"][0]["questions"][0]["id"]  # type: ignore[index]
        status, dlg = req("POST", f"/assessments/{aid}/questions/{qid}/delegate", token,
                          body={"name": "Externo Uno", "email": "externo1@partner.co"})
        check("POST delegate", status == 201, f"status={status}")
        time.sleep(0.6)
        dtoken = delegation_token()
        status, info = req("GET", f"/delegations/{dtoken}")  # public
        check("GET /delegations/{token} (public)", status == 200 and bool(info.get("question_text")),  # type: ignore[union-attr]
              f"status={info.get('status') if isinstance(info, dict) else '?'}")
        status, ans = req("POST", f"/delegations/{dtoken}/answer", body={"value": 4})
        check("POST /delegations/{token}/answer", status == 200 and ans.get("status") == "answered", "")  # type: ignore[union-attr]
        status, info2 = req("GET", f"/delegations/{dtoken}")
        check("delegation status → answered", info2.get("status") == "answered", "")  # type: ignore[union-attr]

        # --- estimator / pricing ---
        status, pricing = req("GET", "/pricing", token)
        check("GET /pricing", status == 200 and pricing.get("base_price") == 500, "")  # type: ignore[union-attr]
        status, dc = req("POST", "/distributor-codes/validate", token, body={"code": "TESTPARTNER"})
        check("POST /distributor-codes/validate", status == 200 and dc.get("discount_pct") == 10, "")  # type: ignore[union-attr]
        status, bad = req("POST", "/distributor-codes/validate", token, body={"code": "NOPE"})
        check("invalid code → 404 DISTRIBUTOR_CODE_INVALID",
              status == 404 and bad.get("error", {}).get("code") == "DISTRIBUTOR_CODE_INVALID", "")  # type: ignore[union-attr]
        status, quote = req("POST", "/estimator/quote", token, body={
            "areas": [{"area_key": "ventas", "active": True, "review": True, "sessions": 2}],
            "final_report": True, "distributor_code": "TESTPARTNER"})
        # 500 + 200 + 300 + 400 = 1400 → -10% = 1260
        check("POST /estimator/quote", status == 200 and quote.get("total") == 1260.0,  # type: ignore[union-attr]
              f"total={quote.get('total') if isinstance(quote, dict) else '?'}")
        quote_id = quote["quote_id"]  # type: ignore[index]

        # --- simulated payment (mock Stripe) ---
        idem = str(uuid.uuid4())
        status, session = req("POST", "/payments/checkout-session", token,
                              body={"quote_id": quote_id,
                                    "success_url": "http://localhost:5173/payment/success",
                                    "cancel_url": "http://localhost:5173/payment/cancel"},
                              headers={"Idempotency-Key": idem})
        url = session.get("checkout_url", "") if isinstance(session, dict) else ""
        check("POST /payments/checkout-session (mock URL)", status == 201 and "mock_session=cs_mock_" in url, url[:80])
        payment_id = session["payment_id"]  # type: ignore[index]
        provider_ref = f"cs_mock_{payment_id}"

        # simulate the webhook like the in-app mock checkout does
        status, wh = req("POST", "/webhooks/stripe", body={
            "id": f"evt_mock_{payment_id}", "type": "checkout.session.completed",
            "data": {"object": {"id": provider_ref, "metadata": {"payment_id": payment_id}}}})
        check("POST /webhooks/stripe (mock completion)", status == 200 and wh.get("received"), "")  # type: ignore[union-attr]

        status, pay = req("GET", f"/payments/{payment_id}", token)
        check("GET /payments/{id} → succeeded", pay.get("status") == "succeeded", "")  # type: ignore[union-attr]

        status, after = req("GET", "/assessments/current", token)
        check("plan upgrade propagated to assessment", after.get("plan") == "pro",  # type: ignore[union-attr]
              f"plan={after.get('plan') if isinstance(after, dict) else '?'}")  # type: ignore[union-attr]

        status, dup = req("POST", "/payments/checkout-session", token, body={"quote_id": quote_id})
        check("re-checkout → 409 PAYMENT_ALREADY_COMPLETED", status == 409, "")

        # --- results (now pro) ---
        status, results = req("GET", f"/results/{aid}", token)
        check("GET /results/{id} (pro)", status == 200 and "maturity" in results,  # type: ignore[operator]
              f"avg={results.get('maturity', {}).get('average') if isinstance(results, dict) else '?'}")

        # --- review ---
        review_status, review = req("POST", "/reviews", token, body={"assessment_id": aid, "mode": "async"})
        check("POST /reviews (pro)", review_status in (201, 409), f"status={review_status}")
        status, reviews = req("GET", f"/reviews?assessment_id={aid}", token)
        check("GET /reviews (assessment)", status == 200 and isinstance(reviews, list), f"status={status}")
        if review_status == 201:
            rid = review["review_id"]  # type: ignore[index]
            status, rstate = req("GET", f"/reviews/{rid}", token)
            check("GET /reviews/{id}", status == 200 and rstate.get("stage") == 1, "")  # type: ignore[union-attr]
            status, rating = req("POST", f"/reviews/{rid}/ratings", token, body={
                "chapter_key": "overall", "knowledge": 5, "friendliness": 4, "methodology": 5,
                "comments": "ok"})
            check("POST /reviews/{id}/ratings", status == 201 and rating.get("average") == 4.7, "")  # type: ignore[union-attr]
            status, _ = req("POST", f"/reviews/{rid}/ratings", token, body={
                "chapter_key": "overall", "knowledge": 5})
            check("incomplete rating → 422 RATING_INCOMPLETE", status == 422, "")

        # --- consultant console ---
        ctoken = login("consultant.phase3@tryaigap.dev")
        status, kpis = req("GET", "/consultant/kpis", ctoken)
        check("GET /consultant/kpis", status == 200 and "leads" in kpis, "")  # type: ignore[operator]
        status, clients = req("GET", "/consultant/clients?plan=pro", ctoken)
        check("GET /consultant/clients (plan filter)", status == 200 and clients.get("meta", {}).get("total", 0) >= 1, "")  # type: ignore[union-attr]
        org_id = clients["items"][0]["client_id"]  # type: ignore[index]
        status, detail = req("GET", f"/consultant/clients/{org_id}", ctoken)
        check("GET /consultant/clients/{id}", status == 200 and len(detail.get("dimensions", [])) == 5, "")  # type: ignore[union-attr]
        status, note = req("POST", f"/consultant/clients/{org_id}/notes", ctoken, body={"body": "nota de prueba"})
        check("POST /consultant/clients/{id}/notes", status == 201, "")
        status, notes = req("GET", f"/consultant/clients/{org_id}/notes", ctoken)
        check(
            "GET /consultant/clients/{id}/notes",
            status == 200 and any(n.get("body") == "nota de prueba" for n in notes),
            f"status={status}",
        )
        status, _ = req("PATCH", f"/admin/users/{client_id}/role", admin_token,
                        body={"role": "client"})
        check("restore client role before authorization check", status == 200, f"status={status}")
        status, _ = req("PATCH", f"/admin/organizations/{org_id}/status", admin_token,
                        body={"status": "suspended"})
        check("admin suspend organization", status == 200, f"status={status}")
        status, _ = req("GET", "/assessments/current", token)
        check("suspended organization rejects client access (403)", status == 403, f"status={status}")
        status, _ = req("PATCH", f"/admin/organizations/{org_id}/status", admin_token,
                        body={"status": "active"})
        check("admin reactivate organization", status == 200, f"status={status}")
        status, _ = req("DELETE", f"/admin/consultant-assignments/{assignment_id}", admin_token)
        check("admin revoke consultant", status == 204, f"status={status}")
        status, _ = req("GET", "/consultant/kpis", token)  # client role
        check("consultant endpoints reject client role (403)", status == 403, "")

    finally:
        proc.terminate()
        try:
            proc.wait(timeout=8)
        except subprocess.TimeoutExpired:
            proc.kill()

    restore_integration_fixtures()

    failed = [r for r in RESULTS if not r[1]]
    print(f"\n{len(RESULTS) - len(failed)}/{len(RESULTS)} checks passed")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
