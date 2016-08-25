#!/usr/bin/env python
# -*- coding: utf-8 -*- 

import json
import csv
from pyexcel_xlsx import get_data
from unicodedata import normalize
import os
import MySQLdb


path_local = os.path.dirname(os.path.realpath(__file__))

with open(path_local+'/data/reservatorios.json') as data_file:
	_reservatorios = json.load(data_file)

with open(path_local+'/data/div_estadual_sab.json') as data_file:
	_div_estadual_sab = json.load(data_file)	

with open(path_local+'/data/estados_br.json') as data_file:
	_estados_br = json.load(data_file)

# with open(path_local+'/data/municipios_sab.json') as data_file:
# 	_municipios_sab = json.load(data_file)

def reservatorios():
	"""return a dictionary"""
	return _reservatorios

# def municipios_sab():
# 	"""return a dictionary"""
# 	return _municipios_sab

def estados_sab():
	"""return a dictionary"""
	return _div_estadual_sab

def estados_br():
	"""return a dictionary"""
	return _estados_br


def consulta_BD(query):
	""" Connect to MySQL database """
	try:
		conn = MySQLdb.connect(read_default_group='INSA')
		cursor = conn.cursor()

		cursor.execute(query)

		rows = cursor.fetchall()

	finally:
		cursor.close()
		conn.close()
	
	return rows
 
