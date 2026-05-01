package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.CustomerTypeDto;
import com.sena.test.Service.SecurityService.CustomerTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/customer-type")
@CrossOrigin(origins = "*")
public class CustomerTypeController {

    @Autowired
    private CustomerTypeService customerTypeService;

    @GetMapping
    public List<CustomerTypeDto> getAll() {
        return customerTypeService.getAll();
    }

    @GetMapping("/{id}")
    public CustomerTypeDto getById(@PathVariable UUID id) {
        return customerTypeService.getById(id);
    }

    @PostMapping
    public CustomerTypeDto create(@RequestBody CustomerTypeDto dto) {
        return customerTypeService.create(dto);
    }

    @PutMapping("/{id}")
    public CustomerTypeDto update(@PathVariable UUID id, @RequestBody CustomerTypeDto dto) {
        return customerTypeService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        customerTypeService.delete(id);
        return "Eliminado exitosamente";
    }
}
