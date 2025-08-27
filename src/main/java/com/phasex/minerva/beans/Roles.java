package com.phasex.minerva.beans;


import lombok.Getter;

@Getter
public enum Roles {
    GERENTE("gerente"),
    VENDEDOR("vendedor"),
    ADMIN("admin");

    private String role;

    Roles(String role){this.role = role;}

}
