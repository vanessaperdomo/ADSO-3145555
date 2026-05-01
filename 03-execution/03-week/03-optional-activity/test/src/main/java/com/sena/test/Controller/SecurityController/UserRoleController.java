package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.UserRoleDto;
import com.sena.test.Service.SecurityService.UserRoleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/user-role")
@CrossOrigin(origins = "*")
public class UserRoleController {

    @Autowired
    private UserRoleService userRoleService;

    @GetMapping
    public List<UserRoleDto> getAll() {
        return userRoleService.getAll();
    }

    @PostMapping
    public UserRoleDto create(@RequestBody UserRoleDto dto) {
        return userRoleService.create(dto);
    }

    // DELETE /api/user-role?userId=...&roleId=...
    @DeleteMapping
    public String delete(@RequestParam UUID userId, @RequestParam UUID roleId) {
        userRoleService.delete(userId, roleId);
        return "Eliminado exitosamente";
    }
}