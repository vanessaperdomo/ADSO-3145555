package com.sena.test.Controller.InventoryController;

import com.sena.test.DTO.InventoryDTO.SupplierDto;
import com.sena.test.Service.InventoryService.SupplierService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/supplier")
@CrossOrigin(origins = "*")
public class SupplierController {

    @Autowired
    private SupplierService supplierService;

    @GetMapping
    public List<SupplierDto> getAll() {
        return supplierService.getAll();
    }

    @GetMapping("/{id}")
    public SupplierDto getById(@PathVariable UUID id) {
        return supplierService.getById(id);
    }

    @PostMapping
    public SupplierDto create(@RequestBody SupplierDto dto) {
        return supplierService.create(dto);
    }

    @PutMapping("/{id}")
    public SupplierDto update(@PathVariable UUID id, @RequestBody SupplierDto dto) {
        return supplierService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        supplierService.delete(id);
        return "Eliminado exitosamente";
    }
}