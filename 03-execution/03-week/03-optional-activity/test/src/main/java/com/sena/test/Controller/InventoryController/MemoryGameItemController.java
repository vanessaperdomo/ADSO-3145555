package com.sena.test.Controller.InventoryController;

import com.sena.test.DTO.InventoryDTO.MemoryGameItemDto;
import com.sena.test.Service.InventoryService.MemoryGameItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/memory-game-item")
@CrossOrigin(origins = "*")
public class MemoryGameItemController {

    @Autowired
    private MemoryGameItemService memoryGameItemService;

    @GetMapping
    public List<MemoryGameItemDto> getAll() {
        return memoryGameItemService.getAll();
    }

    @GetMapping("/{id}")
    public MemoryGameItemDto getById(@PathVariable UUID id) {
        return memoryGameItemService.getById(id);
    }

    @PostMapping
    public MemoryGameItemDto create(@RequestBody MemoryGameItemDto dto) {
        return memoryGameItemService.create(dto);
    }

    @PutMapping("/{id}")
    public MemoryGameItemDto update(@PathVariable UUID id, @RequestBody MemoryGameItemDto dto) {
        return memoryGameItemService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        memoryGameItemService.delete(id);
        return "Eliminado exitosamente";
    }
}
