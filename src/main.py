import datetime
import logging
import os
from google.cloud import bigquery

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def extrair_e_carregar_dados(request):
    logger.info("Iniciando pipeline de dados...")
    project_id = os.environ.get("GCP_PROJECT_ID")
    
    if not project_id:
        return "Erro: Variável GCP_PROJECT_ID faltando", 500

    tabela_ref = f"{project_id}.dataset_clima.dados_diarios"
    client = bigquery.Client()

    dados_api = [{
        "data": str(datetime.date.today()),
        "cidade": "São Paulo",
        "temperatura": 24.5,
        "condicao": "Ensolarado"
    }]

    try:
        erros = client.insert_rows_json(tabela_ref, dados_api)
        if erros:
            logger.error(f"Erros de validação: {erros}")
            return "Erro na validação", 400
        
        logger.info("Dados inseridos com sucesso!")
        return "Sucesso", 200
    except Exception as e:
        logger.critical(f"Erro crítico no pipeline: {str(e)}")
        return "Erro interno", 500