const express = require('express');
const router = express.Router();
const mysql = require('../mysql').pool;
const bcrypt = require('bcrypt');
//const mysql = require('mysql');
const jwt = require('jsonwebtoken');


router.post('/cadastro', (req, res, next) => {

    mysql.getConnection((error, conn) => {
        if (error) {
            return res.status(500).send({ error: error });
        }

        conn.query('SELECT * FROM usuario WHERE usu_email = ?', [req.body.email], (error, resultado) => {
            if (error) {
                conn.release();
                return res.status(500).send({ error: error });
            }

            if (resultado.length > 0) {
                conn.release();
                return res.status(409).send({ mensagem: 'Usuario já cadastrado' });
            } else {
                conn.query('INSERT INTO usuario (usu_nome, usu_email, usu_telefone, usu_endereco, usu_numero, usu_cep, usu_tipo, usu_senha) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
                    [req.body.nome, req.body.email, req.body.telefone, req.body.endereco, req.body.numero, req.body.cep, req.body.tipo, req.body.senha],
                    (error, resultado) => {
                        conn.release();

                        if (error) {
                            return res.status(500).send({ error: error });
                        }

                        const response = {
                            mensagem: 'Usuario criado com sucesso',
                            usuarioCriado: {
                                usu_id: resultado.insertId,
                                nome: req.body.nome,
                                email: req.body.email,
                                telefone: req.body.telefone,
                                endereco: req.body.endereco,
                                numero: req.body.numero,
                                cep: req.body.cep
                            }
                        };

                        return res.status(201).send(response);
                    }
                );
            }
        });
    });

});



router.post('/login', (req, res, next) => {
    mysql.getConnection((error, conn) => {
        if (error) { return res.status(500).send({ error: error }) }
        const query = 'SELECT * FROM usuario WHERE usu_email = ?';
        conn.query(query, [req.body.email], (error, resultado, fields) => {
            conn.release();
            if (error) { return res.status(500).send({ error: error }) }
            if (resultado.length < 1) {
                return res.status(401).send({ mensagem: 'Email não existe' })
            }

            const usuario = resultado[0];

            if (req.body.senha !== usuario.usu_senha) {
                return res.status(401).send({ mensagem: 'Senha incorreta' });
            }


            return res.status(200).send({
                mensagem: 'Autenticado com sucesso', usuario: usuario, // Retorna os detalhes do usuário
            });

        })
    })
});

router.get('/:id_produto', (req, res, next) => {
    mysql.getConnection((error, conn) => {
        if (error) {
            return res.status(500).send({ error: error })
        }
        conn.query(
            'SELECT * FROM produto WHERE pro_id = ?;',
            [req.params.id_produto],
            (error, resultado, fields) => {
                if (error) {
                    return res.status(500).send({ error: error })
                }
                return res.status(200).send({ response: resultado })
            }
        )
    })
});

// retorna os dados
router.get('/getUsers/:id', (req, res) => {
    const idCategoria = req.params.id;

    const query = 'SELECT * FROM usuario where usu_id = ?;';

    mysql.getConnection((error, conn) => {
        if (error) {
            return res.status(500).json({ error: 'Erro ao conectar ao banco de dados' });
        }

        conn.query(query, [idCategoria], (error, resultado, fields) => {
            conn.release();

            if (error) {
                return res.status(500).json({ error: 'Erro ao executar a consulta' });
            }

            if (resultado.length === 0) {
                return res.status(404).json({ mensagem: 'Nenhum usuário encontrado' });
            }

            return res.status(200).json(resultado[0]); // Retorna o primeiro usuário encontrado
        });
    });
});


//atualizar o usuario

router.post('/atualizarUsuario/:usu_id', (req, res) => {
    const usuarioId = req.params.usu_id;
    const { usuNome, usuEmail, usuCpf, usuTelefone, usuEndereco, usuNumero, usuCep } = req.body;

    // Obtenha uma conexão do pool de conexões
    mysql.getConnection((err, conn) => {
        if (err) {
            console.error('Erro ao obter conexão do pool: ' + err.stack);
            return res.status(500).json({ error: 'Erro interno do servidor' });
        }

        // Atualize o usuário no banco de dados
        const sql = 'UPDATE usuario SET usu_nome = ?, usu_email = ?, usu_cpf = ?, usu_telefone = ?, usu_endereco = ?, usu_numero = ?, usu_cep = ? WHERE usu_id = ?';
        conn.query(sql, [usuNome, usuEmail, usuCpf, usuTelefone, usuEndereco, usuNumero, usuCep, usuarioId], (err, result) => {
            conn.release();
            if (err) {
                console.error('Erro ao atualizar o usuário: ' + err.stack);
                return res.status(500).json({ error: 'Erro interno do servidor' });
            }
            res.status(200).json({
                message: 'Usuário atualizado com sucesso', updatedValues: {
                    usuNome: usuNome,
                    usuEmail: usuEmail,
                    usuCpf: usuCpf,
                    usuTelefone: usuTelefone,
                    usuEndereco: usuEndereco,
                    usuNumero: usuNumero,
                    usuCep: usuCep,
                    usuarioId: usuarioId
                }
            });
        });
    });
});



module.exports = router;