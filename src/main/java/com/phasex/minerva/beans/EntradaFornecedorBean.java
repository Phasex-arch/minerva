package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva",name = "entrada_fornecedor",indexes = {
        @Index(name = "idx_ent_fornecedor", columnList = "fornecedor_id"),
        @Index(name = "idx_ent_user", columnList = "user_id"),
        @Index(name = "idx_ent_criado_em", columnList = "criado_em")
})
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class EntradaFornecedorBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fornecedor_id",nullable = false)
    private FornecedorBean fornecedor;

    @Column(length = 6000, nullable = false, name = "nota_ref")
    private String notaRef;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private UserBean user;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;


}
