package com.sena.test.Service.InventoryService;

import com.sena.test.DTO.InventoryDTO.ProductDto;
import com.sena.test.Entity.Inventory.Category;
import com.sena.test.Entity.Inventory.Product;
import com.sena.test.Entity.Inventory.Supplier;
import com.sena.test.IRepository.IInventoryRepository.ICategoryRepository;
import com.sena.test.IRepository.IInventoryRepository.IProductRepository;
import com.sena.test.IRepository.IInventoryRepository.ISupplierRepository;
import com.sena.test.IService.IInventoryService.IProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class ProductService implements IProductService {

    @Autowired
    private IProductRepository repository;

    @Autowired
    private ICategoryRepository categoryRepository;

    @Autowired
    private ISupplierRepository supplierRepository;

    private ProductDto toDto(Product e) {
        ProductDto dto = new ProductDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        dto.setDescription(e.getDescription());
        dto.setPrice(e.getPrice());
        dto.setStock(e.getStock());
        dto.setImageUrl(e.getImageUrl());
        dto.setCategoryId(e.getCategory().getId());
        dto.setSupplierId(e.getSupplier().getId());
        return dto;
    }

    private Product toEntity(ProductDto dto) {
        Product e = new Product();
        e.setName(dto.getName());
        e.setDescription(dto.getDescription());
        e.setPrice(dto.getPrice());
        e.setStock(dto.getStock() != null ? dto.getStock() : 0);
        e.setImageUrl(dto.getImageUrl());
        Category cat = categoryRepository.findById(dto.getCategoryId()).orElse(null);
        e.setCategory(cat);
        Supplier sup = supplierRepository.findById(dto.getSupplierId()).orElse(null);
        e.setSupplier(sup);
        return e;
    }

    @Override
    public List<ProductDto> getAll() {
        return repository.findAll().stream().map(this::toDto).collect(Collectors.toList());
    }

    @Override
    public ProductDto getById(UUID id) {
        Product e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        return toDto(e);
    }

    @Override
    public ProductDto create(ProductDto dto) {
        return toDto(repository.save(toEntity(dto)));
    }

    @Override
    public ProductDto update(UUID id, ProductDto dto) {
        Product e = repository.findById(id).orElse(null);
        if (e == null)
            return null;
        e.setName(dto.getName());
        e.setDescription(dto.getDescription());
        e.setPrice(dto.getPrice());
        e.setStock(dto.getStock());
        e.setImageUrl(dto.getImageUrl());
        Category cat = categoryRepository.findById(dto.getCategoryId()).orElse(null);
        e.setCategory(cat);
        Supplier sup = supplierRepository.findById(dto.getSupplierId()).orElse(null);
        e.setSupplier(sup);
        return toDto(repository.save(e));
    }

    @Override
    public void delete(UUID id) {
        repository.deleteById(id);
    }
}
