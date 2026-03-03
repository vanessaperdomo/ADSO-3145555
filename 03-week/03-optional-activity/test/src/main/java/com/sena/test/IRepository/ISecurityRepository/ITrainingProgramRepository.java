package com.sena.test.IRepository.ISecurityRepository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.sena.test.Entity.Security.TrainingProgram;
import org.springframework.stereotype.Repository;
import java.util.List;
import org.springframework.data.jpa.repository.Query;

@Repository
public interface ITrainingProgramRepository extends JpaRepository<TrainingProgram, Long> {

    @Query("SELECT tp FROM TrainingProgram tp WHERE tp.programName like %?1%")
    List<TrainingProgram> findByProgramName(String programName);
}
