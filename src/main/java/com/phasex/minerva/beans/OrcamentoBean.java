package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;

@Entity
@Table(schema = "minerva", name = "orcamento", indexes = {
                  @Index(name = "idx_orcamento_cliente", columnList = "cliente_id"),
                  @Index(name = "idx_orcamento_status", columnList = "status")
                })

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class OrcamentoBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cliente_id", nullable = false)
    private ClienteBean cliente;

    @ManyToOne(fetch = FetchType.LAZY, optional = true)
    @JoinColumn(name = "criado_por")
    private UserBean criado_por;

    @Column(name = "data", nullable = false, columnDefinition = "date")
    private LocalDate data;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private StatusOrcamento status = StatusOrcamento.ABERTO;

    @org.hibernate.annotations.Check(constraints = "desconto_total >= 0")
    @Column(name = "desconto_total", precision = 10, scale = 2)
    private BigDecimal descontoTotal;

    @Column(name = "observacoes", length = 2000)
    private String observacoes;

    @Column(name = "validade_dias", nullable = false)
    private Integer validadeDias = 7;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;

    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz", nullable = false)
    private java.time.OffsetDateTime  dataAtualizacao;

    @PrePersist
    private void prePersist() {
        if (data == null) data = java.time.LocalDate.now();
        if (status == null) status = StatusOrcamento.ABERTO;
        if (validadeDias == null) validadeDias = 7;
        if (descontoTotal == null) descontoTotal = BigDecimal.ZERO;
    }



}
