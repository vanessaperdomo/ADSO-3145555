package com.sena.test.Utils.InventoryUtils;

import com.sena.test.DTO.InventoryDTO.*;
import com.sena.test.Entity.Inventory.*;

public class InventoryMapper {

    // ── Category ─────────────────────────────────────────────
    public static CategoryDto toDto(Category e) {
        CategoryDto dto = new CategoryDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static Category toEntity(CategoryDto dto) {
        Category e = new Category();
        e.setName(dto.getName());
        return e;
    }

    // ── Supplier ─────────────────────────────────────────────
    public static SupplierDto toDto(Supplier e) {
        SupplierDto dto = new SupplierDto();
        dto.setId(e.getId());
        dto.setName(e.getName());
        return dto;
    }

    public static Supplier toEntity(SupplierDto dto) {
        Supplier e = new Supplier();
        e.setName(dto.getName());
        return e;
    }

    // ── Product ──────────────────────────────────────────────
    public static ProductDto toDto(Product e) {
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

    // ── InventoryMovement ────────────────────────────────────
    public static InventoryMovementDto toDto(InventoryMovement e) {
        InventoryMovementDto dto = new InventoryMovementDto();
        dto.setId(e.getId());
        dto.setMovementType(e.getMovementType());
        dto.setQuantity(e.getQuantity());
        dto.setProductId(e.getProduct().getId());
        dto.setCreatedBy(e.getCreatedBy().getId());
        dto.setCreatedAt(e.getCreatedAt());
        return dto;
    }

    // ── MemoryGameItem ───────────────────────────────────────
    public static MemoryGameItemDto toDto(MemoryGameItem e) {
        MemoryGameItemDto dto = new MemoryGameItemDto();
        dto.setId(e.getId());
        dto.setEnglishName(e.getEnglishName());
        dto.setImageUrl(e.getImageUrl());
        dto.setProductId(e.getProduct().getId());
        return dto;
    }

    public static MemoryGameItem toEntity(MemoryGameItemDto dto) {
        MemoryGameItem e = new MemoryGameItem();
        e.setEnglishName(dto.getEnglishName());
        e.setImageUrl(dto.getImageUrl());
        return e;
    }
}