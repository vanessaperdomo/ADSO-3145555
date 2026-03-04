package com.sena.test.IRepository.ISecurityRepository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.sena.test.Entity.Security.TrainingProgram;
import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface ITrainingProgramRepository extends JpaRepository<TrainingProgram, Long> {

    @Query("SELECT tp FROM TrainingProgram tp WHERE tp.programName like %:programName%")
    List<TrainingProgram> findByProgramName(@Param("programName") String programName);
}
