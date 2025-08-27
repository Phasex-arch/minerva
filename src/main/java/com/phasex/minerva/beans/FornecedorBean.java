package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "fornecedor", indexes = @Index(name = "idx_fornecedor_nome", columnList = "nome"))
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class FornecedorBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nome",nullable = false, length = 120)
    private String nome;

    @Column(name = "contato", nullable = false, length = 120)
    private String contato;

    @Column(name = "lead_time_dias", nullable = false)
    private Integer leadTimeDias;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;

    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime dataAtualizacao;


}
