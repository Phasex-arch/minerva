package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;


@Getter
@Entity
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(of = "id")
@Table(schema = "minerva", name = "agenda_evento")
public class AgendaEventoBean {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "agenda_id", nullable = false)
    private AgendaBean agenda;

    @Column(nullable = false, length = 160)
    private String titulo;

    @Column(length = 6000)
    private String descricao;


    @Column(name = "inicio_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime inicioEm;

    @Column(name = "fim_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime fimEm;

    @Column(length = 160)
    private String local;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;

    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime dataAtualizacao;

}
