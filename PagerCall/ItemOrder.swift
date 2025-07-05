enum ItemOrder: String, CaseIterable {
    case incidentMumberAsc = "incident_number:asc"
    case incidentMumberDesc = "incident_number:desc"
    case createdAtAsc = "created_at:asc"
    case createdAtDesc = "created_at:desc"
    case resolvedAtAsc = "resolved_at:asc"
    case resolvedAtDesc = "resolved_at:desc"
    case urgencyAsc = "urgency:asc"
    case urgencyDesc = "urgency:desc"
}
