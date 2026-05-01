package com.sena.test.Controller.SecurityController;

import com.sena.test.DTO.SecurityDTO.CustomerDto;
import com.sena.test.Service.SecurityService.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/customer")
@CrossOrigin(origins = "*")
public class CustomerController {

    @Autowired
    private CustomerService customerService;

    @GetMapping
    public List<CustomerDto> getAll() {
        return customerService.getAll();
    }

    @GetMapping("/{id}")
    public CustomerDto getById(@PathVariable UUID id) {
        return customerService.getById(id);
    }

    @PostMapping
    public CustomerDto create(@RequestBody CustomerDto dto) {
        return customerService.create(dto);
    }

    @PutMapping("/{id}")
    public CustomerDto update(@PathVariable UUID id, @RequestBody CustomerDto dto) {
        return customerService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        customerService.delete(id);
        return "Eliminado exitosamente";
    }
}
