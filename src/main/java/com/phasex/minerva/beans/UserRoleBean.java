package com.phasex.minerva.beans;


import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.io.Serializable;
import java.util.UUID;

import static jakarta.persistence.FetchType.LAZY;

@Getter
@Setter
@Entity
@Table(schema = "minerva",name = "user_role")
@NoArgsConstructor
public class UserRoleBean{

    @EmbeddedId
    private UserRole userRole;

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name="user_id")
    @MapsId("userId")
    private UserBean user;

    @ManyToOne(fetch = LAZY)
    @JoinColumn(name="role_id")
    @MapsId("roleId")
    private RoleBean role;


    @Embeddable
    @EqualsAndHashCode(of = {"userId","roleId"})
    @NoArgsConstructor
    public static class UserRole implements Serializable {
        private UUID userId;
        private Long roleId;

    }

}
