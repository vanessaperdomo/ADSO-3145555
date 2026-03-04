package com.sena.test.Service.SecurityService;

import java.util.ArrayList;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.sena.test.DTO.SecurityDTO.TrainingGroupDTO;
import com.sena.test.Entity.Security.TrainingGroup;
import com.sena.test.Entity.Security.TrainingProgram;
import com.sena.test.IRepository.ISecurityRepository.ITrainingGroupRepository;
import com.sena.test.IService.ISecurityService.ITrainingGroupService;

@Service
public class TrainingGroupServiceImpl implements ITrainingGroupService {

    @Autowired
    private ITrainingGroupRepository trainingGroupRepository;

    private TrainingGroupDTO mapToDTO(TrainingGroup tg) {
        TrainingGroupDTO dto = new TrainingGroupDTO();
        dto.setId(tg.getId());
        dto.setGroupCode(tg.getGroupCode());
        dto.setProgramId(tg.getProgram().getId());
        return dto; // aqui convierte entidad en DTO
    }

    private TrainingGroup mapToEntity(TrainingGroupDTO dto) {
        TrainingGroup tg = new TrainingGroup();
        tg.setGroupCode(dto.getGroupCode());
        TrainingProgram program = new TrainingProgram();
        program.setId(dto.getProgramId());
        tg.setProgram(program);
        return tg; // aqui convierte DTO en entidad lista para guardar
    }

    @Override
    public List<TrainingGroupDTO> findAll() {
        List<TrainingGroupDTO> result = new ArrayList<>();
        for (TrainingGroup tg : trainingGroupRepository.findAll()) {
            result.add(mapToDTO(tg));
        }
        return result; // aqui busca todos los grupos
    }

    @Override
    public TrainingGroupDTO findById(Long id) {
        TrainingGroup tg = trainingGroupRepository.findById(id).orElse(null);
        return tg != null ? mapToDTO(tg) : null; // aqui busca un grupo por su id
    }

    @Override
    public TrainingGroupDTO save(TrainingGroupDTO dto) {
        return mapToDTO(trainingGroupRepository.save(mapToEntity(dto))); // aqui guarda un nuevo grupo
    }

    @Override
    public TrainingGroupDTO update(Long id, TrainingGroupDTO dto) {
        TrainingGroup tg = trainingGroupRepository.findById(id).orElse(null);
        if (tg == null)
            return null;

        tg.setGroupCode(dto.getGroupCode());
        TrainingProgram program = new TrainingProgram();
        program.setId(dto.getProgramId());
        tg.setProgram(program);
        return mapToDTO(trainingGroupRepository.save(tg)); // aqui guarda los cambios de un grupo existente
    }

    @Override
    public void delete(Long id) {
        trainingGroupRepository.deleteById(id); // aqui elimina un grupo por su id
    }

    @Override
    public List<TrainingGroupDTO> findByProgramId(Long programId) {
        List<TrainingGroupDTO> result = new ArrayList<>();
        for (TrainingGroup tg : trainingGroupRepository.findByProgramId(programId)) {
            result.add(mapToDTO(tg));
        }
        return result; // aqui filtra los grupos por id de programa
    }
}