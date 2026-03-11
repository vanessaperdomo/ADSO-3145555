package com.sena.test.IRepository.ISecurityRepository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.sena.test.Entity.Security.TrainingGroup;

import org.springframework.stereotype.Repository;
import java.util.List;
import org.springframework.data.jpa.repository.Query;

@Repository
public interface ITrainingGroupRepository extends JpaRepository<TrainingGroup, Long> {

    @Query("SELECT tg FROM TrainingGroup tg WHERE tg.program.id=:programId")
    List<TrainingGroup> findByProgramId(Long programId);
}
