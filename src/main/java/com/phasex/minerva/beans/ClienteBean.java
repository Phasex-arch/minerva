package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "cliente")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class ClienteBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nome", nullable = false, length = 50)
    private String nome;

    @Column(name = "telefone", nullable = false, length = 15)
    private String telefone;


    // chego divagarinho contagio geral melho ki facebook ele nao tem igual e uma fofocaiada todo mundo sabe doq q eu to falando é do whatsapp o whatsappp o whatsapp DIGUE Q EU TO DALANDO E DO WHATSAPP
    @Column(name = "whatsapp", length = 15)
    private String whatsapp;

    @Column(name = "observacoes", length = 6000)
    private String observacoes;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;

    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime dataAtualizacao;


    //estou ficando louco
}
