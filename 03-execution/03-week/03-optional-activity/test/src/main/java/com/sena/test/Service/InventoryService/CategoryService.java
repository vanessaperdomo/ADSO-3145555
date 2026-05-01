package com.sena.test.Service.InventoryService;

import com.sena.test.DTO.InventoryDTO.CategoryDto;
import com.sena.test.Entity.Inventory.Category;
import com.sena.test.IRepository.IInventoryRepository.ICategoryRepository;
import com.sena.test.IService.IInventoryService.ICategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class CategoryService implements ICategoryService {

    @Autowired
    private ICategoryRepository repository;

    private CategoryDto toDto(Category e) {
        CategoryDto dto = new CategoryDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    private Category toEntity(CategoryDto dto) {
        Category e = new Category();
        e.setName(dto.getName());
        return e;
    }

    @Override
    public List<CategoryDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public CategoryDto getById(UUID id) {
        Category e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public CategoryDto create(CategoryDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public CategoryDto update(UUID id, CategoryDto dto) {
        Category e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}