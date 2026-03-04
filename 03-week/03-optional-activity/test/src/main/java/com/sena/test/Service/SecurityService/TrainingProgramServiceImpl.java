package com.sena.test.Service.SecurityService;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.sena.test.DTO.SecurityDTO.TrainingProgramDTO;
import com.sena.test.Entity.Security.TrainingProgram;
import com.sena.test.IRepository.ISecurityRepository.ITrainingProgramRepository;
import com.sena.test.IService.ISecurityService.ITrainingProgramService;

@Service
public class TrainingProgramServiceImpl implements ITrainingProgramService {

    @Autowired
    private ITrainingProgramRepository trainingProgramRepository; // acceso a BD

    private TrainingProgramDTO mapToDTO(TrainingProgram tp) {
        TrainingProgramDTO dto = new TrainingProgramDTO();
        dto.setId(tp.getId());
        dto.setProgramName(tp.getProgramName());
        return dto; // devuelve DTO
    }

    // Convierte DTO a entidad
    private TrainingProgram mapToEntity(TrainingProgramDTO dto) {
        TrainingProgram tp = new TrainingProgram();
        tp.setId(dto.getId()); // opcional, útil para update
        tp.setProgramName(dto.getProgramName());
        return tp; // devuelve entidad lista para guardar
    }

    @Override
    public List<TrainingProgramDTO> findAll() {
        List<TrainingProgramDTO> result = new ArrayList<>();
        for (TrainingProgram tp : trainingProgramRepository.findAll()) {
            result.add(mapToDTO(tp));
        }
        return result; // devuelve todos los programas
    }

    @Override
    public TrainingProgramDTO findById(Long id) {
        TrainingProgram tp = trainingProgramRepository.findById(id).orElse(null);
        return tp != null ? mapToDTO(tp) : null; // busca un programa por id
    }

    @Override
    public TrainingProgramDTO save(TrainingProgramDTO dto) {
        return mapToDTO(trainingProgramRepository.save(mapToEntity(dto))); // guarda un nuevo programa
    }

    @Override
    public TrainingProgramDTO update(Long id, TrainingProgramDTO dto) {
        TrainingProgram tp = trainingProgramRepository.findById(id).orElse(null);
        if (tp == null)
            return null;

        tp.setProgramName(dto.getProgramName()); // actualiza nombre
        return mapToDTO(trainingProgramRepository.save(tp)); // guarda cambios
    }

    @Override
    public void delete(Long id) {
        trainingProgramRepository.deleteById(id); // elimina por id
    }

    @Override
    public List<TrainingProgramDTO> findByProgramName(String programName) {
        List<TrainingProgramDTO> result = new ArrayList<>();
        for (TrainingProgram tp : trainingProgramRepository.findByProgramName(programName)) {
            result.add(mapToDTO(tp));
        }
        return result; // filtra programas por nombre
    }
}