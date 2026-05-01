package com.sena.test.Controller.InventoryController;

import com.sena.test.DTO.InventoryDTO.InventoryMovementDto;
import com.sena.test.Service.InventoryService.InventoryMovementService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/inventory-movement")
@CrossOrigin(origins = "*")
public class InventoryMovementController {

    @Autowired
    private InventoryMovementService inventoryMovementService;

    @GetMapping
    public List<InventoryMovementDto> getAll() {
        return inventoryMovementService.getAll();
    }

    @GetMapping("/{id}")
    public InventoryMovementDto getById(@PathVariable UUID id) {
        return inventoryMovementService.getById(id);
    }

    @PostMapping
    public InventoryMovementDto create(@RequestBody InventoryMovementDto dto) {
        return inventoryMovementService.create(dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        inventoryMovementService.delete(id);
        return "Eliminado exitosamente";
    }
}
