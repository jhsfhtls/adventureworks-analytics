"""
Módulo de Integração de Webhooks (Microsoft Teams & Slack)
Suporta envio HTTP real ou modo Simulação (Console).
"""

import json
import os
import urllib.request

from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

TEAMS_WEBHOOK_URL = os.getenv("TEAMS_WEBHOOK_URL", "")
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL", "")


def send_teams_alert(
    title: str, subtitle: str, summary_text: str, facts: list, color: str = "d9534f"
) -> bool:
    """
    Envia ou simula um MessageCard formatado para o Microsoft Teams.
    color: 'd9534f' (vermelho), 'f0ad4e' (amarelo/laranja), '5cb85c' (verde)
    """
    payload = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": color,
        "summary": title,
        "sections": [
            {
                "activityTitle": f"🔔 **{title}**",
                "activitySubtitle": subtitle,
                "text": summary_text,
                "facts": facts,
                "markdown": True,
            }
        ],
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": "📊 Abrir Power BI Dashboard",
                "targets": [{"os": "default", "uri": "https://app.powerbi.com"}],
            }
        ],
    }

    if not TEAMS_WEBHOOK_URL:
        # Modo Simulação (Console)
        print(f"\n[SIMULAÇÃO TEAMS] -> {title}")
        print(f"Resumo: {summary_text}")
        for fact in facts:
            print(f"   • {fact['name']}: {fact['value']}")
        return True

    # Envio Real HTTP POST
    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            TEAMS_WEBHOOK_URL, data=data, headers={"Content-Type": "application/json"}
        )
        with urllib.request.urlopen(req) as response:
            return response.status == 200
    except Exception as e:
        print(f"❌ Erro ao enviar webhook para o Teams: {e}")
        return False
