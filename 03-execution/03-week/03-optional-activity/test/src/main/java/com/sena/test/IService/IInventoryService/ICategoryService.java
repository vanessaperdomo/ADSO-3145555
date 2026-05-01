package com.sena.test.IService.IInventoryService;

import com.sena.test.DTO.InventoryDTO.CategoryDto;
import java.util.List;
import java.util.UUID;

public interface ICategoryService {
    List<CategoryDto> getAll();

    CategoryDto getById(UUID id);

    CategoryDto create(CategoryDto dto);

    CategoryDto update(UUID id, CategoryDto dto);

    void delete(UUID id);
}