package com.sena.test.Controller.InventoryController;

import com.sena.test.DTO.InventoryDTO.CategoryDto;
import com.sena.test.Service.InventoryService.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/category")
@CrossOrigin(origins = "*")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping
    public List<CategoryDto> getAll() {
        return categoryService.getAll();
    }

    @GetMapping("/{id}")
    public CategoryDto getById(@PathVariable UUID id) {
        return categoryService.getById(id);
    }

    @PostMapping
    public CategoryDto create(@RequestBody CategoryDto dto) {
        return categoryService.create(dto);
    }

    @PutMapping("/{id}")
    public CategoryDto update(@PathVariable UUID id, @RequestBody CategoryDto dto) {
        return categoryService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        categoryService.delete(id);
        return "Eliminado exitosamente";
    }
}