package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(schema = "minerva",name = "role")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(of = {"id"})
public class RoleBean {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nome", nullable = false, unique = true, length = 64)
    private String cargo;

    public RoleBean(String cargo) {
        this.cargo = cargo;
    }

}
