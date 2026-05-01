package com.sena.test.Service.InventoryService;

import com.sena.test.DTO.InventoryDTO.MemoryGameItemDto;
import com.sena.test.Entity.Inventory.MemoryGameItem;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.IRepository.IInventoryRepository.IMemoryGameItemRepository;
import com.sena.test.IRepository.IInventoryRepository.IProductRepository;
import com.sena.test.IService.IInventoryService.IMemoryGameItemService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MemoryGameItemService implements IMemoryGameItemService {

    @Autowired
    private IMemoryGameItemRepository repository;

    @Autowired
    private IProductRepository productRepository;

    private MemoryGameItemDto toDto(MemoryGameItem e) {
        MemoryGameItemDto dto = new MemoryGameItemDto();
        dto.setId(e.getId());
        dto.setEnglishName(e.getEnglishName());
        dto.setImageUrl(e.getImageUrl());
        dto.setProductId(e.getProduct().getId());
        return dto;
    }

    private MemoryGameItem toEntity(MemoryGameItemDto dto) {
        MemoryGameItem e = new MemoryGameItem();
        e.setEnglishName(dto.getEnglishName());
        e.setImageUrl(dto.getImageUrl());
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        return e;
    }

    @Override
    public List<MemoryGameItemDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public MemoryGameItemDto getById(UUID id) {
        MemoryGameItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public MemoryGameItemDto create(MemoryGameItemDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public MemoryGameItemDto update(UUID id, MemoryGameItemDto dto) {
        MemoryGameItem e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setEnglishName(dto.getEnglishName());
        e.setImageUrl(dto.getImageUrl());
        Product product = productRepository.findById(dto.getProductId()).orElse(null);
        e.setProduct(product);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}