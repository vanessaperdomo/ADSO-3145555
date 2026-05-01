package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.StudyGroupDto;
import com.sena.test.Service.SecurityService.StudyGroupService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/study-group")
@CrossOrigin(origins = "*")
public class StudyGroupController {

    @Autowired
    private StudyGroupService studyGroupService;

    @GetMapping
    public List<StudyGroupDto> getAll() {
        return studyGroupService.getAll();
    }

    @GetMapping("/{id}")
    public StudyGroupDto getById(@PathVariable UUID id) {
        return studyGroupService.getById(id);
    }

    @PostMapping
    public StudyGroupDto create(@RequestBody StudyGroupDto dto) {
        return studyGroupService.create(dto);
    }

    @PutMapping("/{id}")
    public StudyGroupDto update(@PathVariable UUID id, @RequestBody StudyGroupDto dto) {
        return studyGroupService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        studyGroupService.delete(id);
        return "Eliminado exitosamente";
    }
}