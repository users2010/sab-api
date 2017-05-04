#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
from bs4 import BeautifulSoup
import requests
from unicodedata import normalize
from fuzzywuzzy import fuzz
import re
from datetime import datetime
import aux_collection_insert


reload(sys)
sys.setdefaultencoding('utf8')

def remove_accents(txt):
	if (type(txt) is str):
		txt= unicode(txt, "utf-8")
	return normalize('NFKD', txt).encode('ASCII','ignore').decode('ASCII')

paraiba = aux_collection_insert.consulta_BD("SELECT DISTINCT r.id id_reservatorio, r.nome nome_reservatorio, r.reservat reservat, r.capacidade capacidade,"
				" mo2.data_info data_info, mo2.cota cota, mo2.volume volume, mo2.volume_percentual volumePercentual "
				"FROM tb_estado e, tb_municipio mu, tb_reservatorio_municipio rm, tb_reservatorio r, "
				"(SELECT mon.id id_reservatorio, mo.cota, mo.volume, mo.volume_percentual, date_format(mo.data_informacao,'%d-%m-%Y') data_info "
				"FROM tb_monitoramento mo RIGHT JOIN (SELECT r.id, max(m.data_informacao) AS maior_data FROM tb_reservatorio r "
				"LEFT OUTER JOIN tb_monitoramento m ON r.id=m.id_reservatorio GROUP BY r.id) mon ON mo.id_reservatorio=mon.id "
				"AND mon.maior_data=mo.data_informacao) mo2 WHERE e.id = mu.id_estado and mu.id=rm.id_municipio and rm.id_reservatorio=r.id "
				"and r.id=mo2.id_reservatorio and e.sigla='PB';")

r = requests.get('http://site2.aesa.pb.gov.br/aesa/volumesAcudes.do?metodo=preparaUltimosVolumesPorAcude2')

json_reservatorio = {}
contador_coluna = 0

soup = BeautifulSoup(r.text.decode('utf8'), 'html.parser')

tabela = soup.find('table', { "class" : "tabelaInternaTituloForm" })

cabecalho = ['Municipio','Reservatorio','CapacidadeMaxima','Volume','VolumePercentual','DataInformacao']

colunas = tabela.find_all('td')

to_insert = []
for num_coluna in range(len(cabecalho),len(colunas)):
	if(contador_coluna < len(cabecalho)):
	 	json_reservatorio[cabecalho[contador_coluna]] = colunas[num_coluna].get_text().strip()
		contador_coluna +=1
	if(contador_coluna == len(cabecalho)):
	 	contador_coluna = 0
		for reserv in paraiba:
			similaridade_acude = fuzz.token_set_ratio(remove_accents(reserv[1]),remove_accents(json_reservatorio["Reservatorio"]))
			apelido = re.sub(remove_accents(reserv[1])+'|acude|barragem|lagoa|[()-]| do | da | de ','',remove_accents(reserv[2]), flags=re.IGNORECASE).strip()
			similaridade_apelido = fuzz.token_set_ratio(remove_accents(apelido),remove_accents(json_reservatorio["Reservatorio"]))
			capacidade = round(float(json_reservatorio["CapacidadeMaxima"])/1000000,2)
			if ((similaridade_acude>=80 or similaridade_apelido>=80) and float(capacidade)==float(reserv[3])):
				if ((reserv[4] is None) or (datetime.strptime(reserv[4], '%d-%m-%Y') < datetime.strptime(json_reservatorio["DataInformacao"], '%d/%m/%Y'))):
					ultimo_monitoramento = [reserv[0],reserv[5], reserv[6], reserv[7], reserv[4]]
					to_add = [[reserv[0],'',round(float(json_reservatorio["Volume"])/1000000,2), (float(json_reservatorio["Volume"])/float(json_reservatorio["CapacidadeMaxima"]))*100,
						datetime.strptime(json_reservatorio["DataInformacao"], '%d/%m/%Y').strftime('%Y-%m-%d')]]
					to_insert.extend(aux_collection_insert.retira_ruido(to_add,ultimo_monitoramento, "AESA"))

					# RESERVATORIOS ATUALIZADOS
					aux_collection_insert.update_BD("UPDATE tb_user_reservatorio SET atualizacao_reservatorio = 1 WHERE id_reservatorio="+str(reserv[0])+";")

		json_reservatorio={}

aux_collection_insert.insert_many_BD(to_insert)