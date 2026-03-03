package com.sena.test.IService.ISecurityService;

import java.util.List;
import com.sena.test.DTO.SecurityDTO.TrainingGroupDTO;

public interface ITrainingGroupService {

    List<TrainingGroupDTO> findAll();

    TrainingGroupDTO findById(Long id);

    TrainingGroupDTO save(TrainingGroupDTO trainingGroupDTO);

    TrainingGroupDTO update(Long id, TrainingGroupDTO trainingGroupDTO);

    void delete(Long id);

    List<TrainingGroupDTO> findByProgramId(Long programId);
}
