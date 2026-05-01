package com.sena.test.Controller.BillController;

import com.sena.test.DTO.BillDTO.OrderStatusDto;
import com.sena.test.Service.BillService.OrderStatusService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/order-status")
@CrossOrigin(origins = "*")
public class OrderStatusController {

    @Autowired
    private OrderStatusService orderStatusService;

    @GetMapping
    public List<OrderStatusDto> getAll() {
        return orderStatusService.getAll();
    }

    @GetMapping("/{id}")
    public OrderStatusDto getById(@PathVariable UUID id) {
        return orderStatusService.getById(id);
    }

    @PostMapping
    public OrderStatusDto create(@RequestBody OrderStatusDto dto) {
        return orderStatusService.create(dto);
    }

    @PutMapping("/{id}")
    public OrderStatusDto update(@PathVariable UUID id, @RequestBody OrderStatusDto dto) {
        return orderStatusService.update(id, dto);
    }

    @DeleteMapping("/{id}")
    public String delete(@PathVariable UUID id) {
        orderStatusService.delete(id);
        return "Eliminado exitosamente";
    }
}
