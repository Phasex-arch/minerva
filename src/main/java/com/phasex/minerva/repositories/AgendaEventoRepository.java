package com.phasex.minerva.repositories;

import com.phasex.minerva.beans.AgendaBean;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface AgendaEventoRepository extends JpaRepository<AgendaBean, UUID> {

}
