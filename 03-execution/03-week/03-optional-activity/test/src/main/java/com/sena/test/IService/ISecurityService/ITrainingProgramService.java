package com.sena.test.IService.ISecurityService;

import java.util.List;
import com.sena.test.DTO.SecurityDTO.TrainingProgramDTO;

public interface ITrainingProgramService {

    List<TrainingProgramDTO> findAll();

    TrainingProgramDTO findById(Long id);

    TrainingProgramDTO save(TrainingProgramDTO trainingProgramDTO);

    TrainingProgramDTO update(Long id, TrainingProgramDTO trainingProgramDTO);

    void delete(Long id);

    List<TrainingProgramDTO> findByProgramName(String programName);
}
