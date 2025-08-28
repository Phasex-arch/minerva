package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(schema = "minerva", name = "item_orcamento")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class ItemOrcamentoBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // TODO: TERMINAR ESSE ITEM AQUI
}
