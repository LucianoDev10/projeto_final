const axios = require('axios');
const express = require('express');
const router = express.Router();
const req = require('express/lib/request');
const { poolPromise } = require('../mysql');
const mysql = require('../mysql').pool;
const mysqlPromise = require('../mysql').poolPromise;



router.get('/', async (req, res) => {
    try {
        const query = 'SELECT * FROM pedidos';
        const [resultado] = await poolPromise.execute(query);

        if (resultado.length === 0) {
            return res.status(404).json({ mensagem: 'Nenhum pedido encontrado para este usuário' });
        }

        return res.status(200).json({ response: resultado });
    } catch (error) {
        console.error('Erro na requisição: ', error);
        return res.status(500).json({ mensagem: 'Erro interno do servidor' });
    }
});

router.post('/', async (req, res, next) => {
    const { ped_id, ped_data, usu_id, ped_TipoPagamento, ped_valorTotal, ped_frete, ped_distancia, ped_rota } = req.body;

    try {
        // Inserir novo pedido no banco de dados
        const insertQuery = `
            INSERT INTO pedidos (ped_id, ped_data, usu_id, ped_TipoPagamento, ped_valorTotal, ped_frete, ped_distancia, ped_rota)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        `;

        const values = [ped_id, ped_data, usu_id, ped_TipoPagamento, ped_valorTotal, ped_frete, ped_distancia, ped_rota];
        await poolPromise.execute(insertQuery, values);

        // Enviar dados para a planilha usando a API do SheetDB
        await enviarDadosParaPlanilha([{ ped_id, ped_data, usu_id, ped_TipoPagamento, ped_valorTotal, ped_frete, ped_distancia, ped_rota }]);

        res.json({ message: 'Pedido criado e dados enviados para a planilha com sucesso' });
    } catch (error) {
        console.error('Erro ao criar pedido: ', error);
        res.status(500).json({ error: 'Erro interno do servidor', details: error.message });
    }
});

// Função para enviar dados para a planilha usando a API do SheetDB


module.exports = router;
