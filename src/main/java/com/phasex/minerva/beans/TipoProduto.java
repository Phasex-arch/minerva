package com.phasex.minerva.beans;

import lombok.Getter;

@Getter
public enum TipoProduto {
    TAPETE("tapete"),
    CORTINA("cortina"),
    PERSIANA("persiana"),
    DECORACAO("decoracao");

    private String tipo;

    TipoProduto(String tipo) {
        this.tipo = tipo;
    }


}
