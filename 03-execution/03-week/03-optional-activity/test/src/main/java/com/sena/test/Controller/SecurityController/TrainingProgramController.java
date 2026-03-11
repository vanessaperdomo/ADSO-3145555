package com.sena.test.Controller.SecurityController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.sena.test.DTO.SecurityDTO.TrainingProgramDTO;
import com.sena.test.IService.ISecurityService.ITrainingProgramService;

@RestController
@RequestMapping("/trainingProgram")
public class TrainingProgramController {

    @Autowired
    private ITrainingProgramService trainingProgramService;

    @GetMapping("") // aqui trae todos los training programs
    public ResponseEntity<Object> findAll() {
        List<TrainingProgramDTO> programs = trainingProgramService.findAll();
        return new ResponseEntity<Object>(programs, HttpStatus.OK);
    }

    @PostMapping("") // aqui crea un training program
    public ResponseEntity<Object>save(@RequestBody TrainingProgramDTO trainingProgramDTO){
        trainingProgramService.save(trainingProgramDTO);
        return new ResponseEntity<Object>("Programa creado correctamente", HttpStatus.OK);
    }

    @GetMapping("{id}") // aqui busca un training program por id
    public ResponseEntity<Object>findById(@PathVariable Long id){
        TrainingProgramDTO program = trainingProgramService.findById(id);
        if(program != null){
            return new ResponseEntity<Object>(program, HttpStatus.OK);
        } else {
            return new ResponseEntity<Object>("Programa no encontrado", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("filterbyname/{nombre}") // aqui filtra los training programs por nombre

}
