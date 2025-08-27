package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "estoque",
        indexes = @Index(name = "idx_estoque_produto", columnList = "produto_id"))
        @org.hibernate.annotations.Check(constraints = "quantidade >= 0")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class EstoqueBean {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "produto_id", nullable = false)
    private ProdutoBean produto;

    @Column(name = "quantidade", nullable = false)
    @jakarta.validation.constraints.Min(0)
    private Integer quantidade;

    @Column(name = "localizacao", nullable = false)
    private String localizacao;

    @Column(name = "alerta_minimo", nullable = false)
    @jakarta.validation.constraints.Min(0)
    private Integer alertaMinimo;

    @org.hibernate.annotations.CreationTimestamp
    @Column(name = "criado_em", columnDefinition = "timestamptz",nullable = false, updatable = false)
    private java.time.OffsetDateTime dataCriacao;

    @org.hibernate.annotations.UpdateTimestamp
    @Column(name = "atualizado_em", columnDefinition = "timestamptz",nullable = false)
    private java.time.OffsetDateTime dataAtualizacao;

    @Version
    private Long version;
}
