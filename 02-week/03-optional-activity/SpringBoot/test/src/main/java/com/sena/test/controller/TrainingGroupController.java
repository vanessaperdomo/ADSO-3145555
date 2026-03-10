package com.sena.test.Controller.SecurityController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.sena.test.DTO.SecurityDTO.TrainingGroupDTO;
import com.sena.test.IService.ISecurityService.ITrainingGroupService;

@RestController
@RequestMapping("/trainingGroup")
public class TrainingGroupController {

    @Autowired
    private ITrainingGroupService trainingGroupService;

    @GetMapping("") // aqui trae todos los training groups
    public ResponseEntity<Object> findAll() {
        List<TrainingGroupDTO> groups = trainingGroupService.findAll();
        return new ResponseEntity<>(groups, HttpStatus.OK);
    }

    @PostMapping("") // aqui crea un training group
    public ResponseEntity<Object> save(@RequestBody TrainingGroupDTO trainingGroupDTO) {
        trainingGroupService.save(trainingGroupDTO);
        return new ResponseEntity<Object>("Grupo creado correctamente", HttpStatus.OK);
    }

    @GetMapping("{id}") // aqui busca un training group por id
    public ResponseEntity<Object> findById(@PathVariable Long id) {
        TrainingGroupDTO group = trainingGroupService.findById(id);
        if (group != null) {
            return new ResponseEntity<>(group, HttpStatus.OK);
        } else {
            return new ResponseEntity<>("Grupo no encontrado", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("filterbyname/{nombre}") // aqui filtra los training groups por nombre
    public ResponseEntity<Object> findByProgramId(@PathVariable Long programId) {
        List<TrainingGroupDTO> groups = trainingGroupService.findByProgramId(programId);
        return new ResponseEntity<>(groups, HttpStatus.OK);
    }

    @DeleteMapping("{id}") // aqui elimina un training group por id
    public ResponseEntity<Object> delete(@PathVariable Long id) {
        trainingGroupService.delete(id);
        return new ResponseEntity<Object>("Grupo eliminado", HttpStatus.OK);
    }

    @PutMapping("{id}") // aqui actualiza un training group por id
    public ResponseEntity<Object> update(@PathVariable Long id, @RequestBody TrainingGroupDTO trainingGroupDTO) {
        trainingGroupService.update(id, trainingGroupDTO);
        return new ResponseEntity<Object>("Grupo actualizado exitosamente", HttpStatus.OK);
    }
}
