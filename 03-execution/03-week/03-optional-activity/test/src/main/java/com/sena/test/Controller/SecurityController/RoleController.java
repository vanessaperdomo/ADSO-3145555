package com.sena.test.Controller.SecurityController;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.sena.test.DTO.SecurityDTO.RoleDTO;
import com.sena.test.IService.ISecurityService.IRoleService;

@RestController
@RequestMapping("/rol")
public class RoleController {

    @Autowired
    private IRoleService roleService;

    @GetMapping("") // aqui trae todos los roles
    public ResponseEntity<Object> findAll() {
        List<RoleDTO> roles = roleService.findAll();
        return new ResponseEntity<Object>(roles, HttpStatus.OK);
    }

    @PostMapping("") // aqui crea un rol
    public ResponseEntity<Object> save(@RequestBody RoleDTO roleDTO) {
        roleService.save(roleDTO);
        return new ResponseEntity<Object>("Role creado exitosamente", HttpStatus.OK);
    }

    @GetMapping("{id}") // aqui busca un rol por id
    public ResponseEntity<Object> findById(@PathVariable Long id) {
        RoleDTO role = roleService.findById(id);
        if (role != null) {
            return new ResponseEntity<Object>(role, HttpStatus.OK);
        } else {
            return new ResponseEntity<Object>("Role no encontrado", HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("filterbyname/{nombre}") // aqui filtra los roles por nombre
    public ResponseEntity<Object> filterByName(@PathVariable String nombre) {
        List<RoleDTO> roles = roleService.filterByName(nombre);
        return new ResponseEntity<Object>(roles, HttpStatus.OK);
    }

    @DeleteMapping("{id}") // aqui elimina un rol por id
    public ResponseEntity<Object> delete(@PathVariable Long id) {
        roleService.delete(id);
        return new ResponseEntity<Object>("Rol eliminado", HttpStatus.OK);
    }

    @PutMapping("{id}") // aqui actualiza un rol por id
    public ResponseEntity<Object> update(@PathVariable Long id, @RequestBody RoleDTO roleDTO) {
        roleService.update(id, roleDTO);
        return new ResponseEntity<Object>("Rol actualizado exitosamente", HttpStatus.OK);
    }
}
