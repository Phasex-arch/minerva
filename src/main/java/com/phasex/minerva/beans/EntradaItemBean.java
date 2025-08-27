package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "entrada_item",indexes = {
            @Index(name = "idx_entrada_item_entrada", columnList = "entrada_id"),
            @Index(name = "idx_entrada_item_produto", columnList = "produto_id")
          })
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class EntradaItemBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "entrada_id",nullable = false)
    private EntradaFornecedorBean entradaFornecedor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "produto_id", nullable = false)
    private ProdutoBean produto;

    @Column(name = "quantidade")
    @jakarta.validation.constraints.Min(1)
    private Long quantidade;

}
