"""Transactional email via generic SMTP, with console fallback for dev."""
import asyncio
import logging
import smtplib
from email.message import EmailMessage

from app.core.config import settings

log = logging.getLogger("app.email")


def _smtp_configured() -> bool:
    return bool(settings.smtp_host)


def _send_smtp_sync(to: str, subject: str, html: str) -> None:
    msg = EmailMessage()
    msg["From"] = settings.smtp_from_address
    msg["To"] = to
    msg["Subject"] = subject
    msg.set_content("Este mensaje requiere un cliente de correo con HTML.")
    msg.add_alternative(html, subtype="html")

    with smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=30) as smtp:
        if settings.smtp_use_tls:
            smtp.starttls()
        if settings.smtp_username:
            smtp.login(settings.smtp_username, settings.smtp_password)
        smtp.send_message(msg)


async def send_email(to: str, subject: str, html: str) -> None:
    if not _smtp_configured():
        log.info("EMAIL (console fallback) to=%s subject=%s\n%s", to, subject, html)
        return
    await asyncio.to_thread(_send_smtp_sync, to, subject, html)


def magic_link_email(link: str, locale: str = "es") -> tuple[str, str]:
    subjects = {
        "es": "Tu enlace de acceso", "en": "Your sign-in link",
        "de": "Ihr Anmeldelink", "pt": "Seu link de acesso",
    }
    body = {
        "es": f'<p>Accede con este enlace (válido 15 min):</p><p><a href="{link}">Iniciar sesión</a></p>',
        "en": f'<p>Sign in with this link (valid 15 min):</p><p><a href="{link}">Sign in</a></p>',
        "de": f'<p>Melden Sie sich über diesen Link an (15 Min gültig):</p><p><a href="{link}">Anmelden</a></p>',
        "pt": f'<p>Acesse com este link (válido 15 min):</p><p><a href="{link}">Entrar</a></p>',
    }
    return subjects.get(locale, subjects["es"]), body.get(locale, body["es"])
