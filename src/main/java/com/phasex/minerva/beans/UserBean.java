package com.phasex.minerva.beans;


import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

import java.sql.Timestamp;
import java.util.UUID;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(schema = "minerva",name = "app_user")
@EqualsAndHashCode(of = {"id"})
public class UserBean {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Email
    @NotBlank
    @Column(nullable = false, unique = true)
    private String email;

    private String telefone;

    @NotBlank
    @Column(nullable = false, name = "senha_hash", length = 100)
    private String senhaHash;

    private Boolean ativo;
    private Timestamp dataCriacao;
    private Timestamp dataAtualizacao;

    public UserBean(String email, String telefone, String senha) {
        this.email = email;
        this.telefone = telefone;
        this.senhaHash = senha;
        this.ativo = true;
        this.dataCriacao = new Timestamp(System.currentTimeMillis());
        this.dataAtualizacao = new Timestamp(System.currentTimeMillis());
    }






}

