package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "produto",
        indexes = {
        @Index(name = "idx_produto_nome", columnList = "nome") })
@org.hibernate.annotations.Check(constraints = "preco_por_peca IS NOT NULL OR preco_por_m2 IS NOT NULL")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class ProdutoBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "sku", nullable = false, unique = true, length = 64)
    private String sku;

    @Column(name = "nome", nullable = false, length = 160)
    private String nome;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_produto", nullable = false, length = 50)
    private TipoProduto tipo;

    @Column(name = "categoria", nullable = false, length = 80)
    private String categoria;

    @Column(name = "material", nullable = false, length = 80)
    private String material;

    @Column(name = "cor", nullable = false, length = 48)
    private String cor;

    @Column(name = "largura_cm", precision = 10, scale = 2)
    private java.math.BigDecimal larguraCm;

    @Column(name = "altura_cm", precision = 10, scale = 2)
    private java.math.BigDecimal alturaCm;

    @Column(name = "comprimento_cm")
    private java.math.BigDecimal comprimentoCm;

    @Column(name = "preco_por_peca")
    private Long precoPorPeca; // Deixar em Long pra ser por centavos e na hora de exibir pra usuario dividir por 100

    @Column(name = "preco_por_m2")
    private Long precoPorM2; // mesma coisa, se pa devia coloca isso como regra de negocio, chapei

    @Column(name = "sob_medida", nullable = false)
    private Boolean sobMedida = false;

    @Column(name = "observacoes" , length = 2000)
    private String observacoes;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;


    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz", nullable = false)
    private java.time.OffsetDateTime  dataAtualizacao;


}
