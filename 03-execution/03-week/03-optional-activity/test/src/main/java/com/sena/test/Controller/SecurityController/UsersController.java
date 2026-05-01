package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.UsersDto;
import com.sena.test.Service.SecurityService.UsersService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UsersController {

    @Autowired
    private UsersService usersService;

    @GetMapping
    public List<UsersDto> getAll() {
        return usersService.getAll();
    }

    @GetMapping("/{id}")
    public UsersDto getById(@PathVariable UUID id) {
        return usersService.getById(id);
    }

    @PostMapping
    public UsersDto create(@RequestBody UsersDto dto) {
        return usersService.create(dto);
    }

    @PutMapping("/{id}")
    public UsersDto update(@PathVariable UUID id, @RequestBody UsersDto dto) {
        return usersService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        usersService.delete(id);
        return "Eliminado exitosamente";
    }
}
