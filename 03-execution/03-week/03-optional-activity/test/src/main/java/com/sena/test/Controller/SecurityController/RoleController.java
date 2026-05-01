package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.RoleDto;
import com.sena.test.Service.SecurityService.RoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/role")
@CrossOrigin(origins = "*")
public class RoleController {

    @Autowired
    private RoleService roleService;

    @GetMapping
    public List<RoleDto> getAll() {
        return roleService.getAll();
    }

    @GetMapping("/{id}")
    public RoleDto getById(@PathVariable UUID id) {
        return roleService.getById(id);
    }

    @PostMapping
    public RoleDto create(@RequestBody RoleDto dto) {
        return roleService.create(dto);
    }

    @PutMapping("/{id}")
    public RoleDto update(@PathVariable UUID id, @RequestBody RoleDto dto) {
        return roleService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        roleService.delete(id);
        return "Eliminado exitosamente";
    }
}