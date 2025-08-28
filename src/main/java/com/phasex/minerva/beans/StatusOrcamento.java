package com.phasex.minerva.beans;


import lombok.Getter;

@Getter
public enum StatusOrcamento {
    ABERTO("aberto"),
    ENVIADO("enviado"),
    APROVADO("aprovado"),
    CANCELADO("cancelado");

    private String status;

    StatusOrcamento(String status) { this.status = status; }
}
