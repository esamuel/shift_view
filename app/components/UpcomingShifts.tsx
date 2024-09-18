import React from 'react';
import { Shift } from '@/types'; // Assuming Shift type is defined in a types file

function formatShiftInfo(shift) {
  return `${shift.startTime} - ${shift.endTime}`;
}

function UpcomingShifts({ shifts }: { shifts: Shift[] }) {
  return (
    <div>
      {shifts.map((shift) => (
        <div key={shift.id}>
          <p>{formatShiftInfo(shift)}</p>
        </div>
      ))}
    </div>
  );
}