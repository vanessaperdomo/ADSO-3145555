package com.sena.test.IService.IInventoryService;

import com.sena.test.DTO.InventoryDTO.ProductDto;
import java.util.List;
import java.util.UUID;

public interface IProductService {
    List<ProductDto> getAll();

    ProductDto getById(UUID id);

    ProductDto create(ProductDto dto);

    ProductDto update(UUID id, ProductDto dto);

    void delete(UUID id);
}