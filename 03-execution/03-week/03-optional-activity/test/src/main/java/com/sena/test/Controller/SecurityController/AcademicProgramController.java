package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.AcademicProgramDto;
import com.sena.test.Service.SecurityService.AcademicProgramService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/academic-program")
@CrossOrigin(origins = "*")
public class AcademicProgramController {

    @Autowired
    private AcademicProgramService academicProgramService;

    @GetMapping
    public List<AcademicProgramDto> getAll() {
        return academicProgramService.getAll();
    }

    @GetMapping("/{id}")
    public AcademicProgramDto getById(@PathVariable UUID id) {
        return academicProgramService.getById(id);
    }

    @PostMapping
    public AcademicProgramDto create(@RequestBody AcademicProgramDto dto) {
        return academicProgramService.create(dto);
    }

    @PutMapping("/{id}")
    public AcademicProgramDto update(@PathVariable UUID id, @RequestBody AcademicProgramDto dto) {
        return academicProgramService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        academicProgramService.delete(id);
        return "Eliminado exitosamente";
    }
}