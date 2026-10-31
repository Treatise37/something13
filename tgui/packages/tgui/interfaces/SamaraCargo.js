import { useBackend } from '../backend';
import { AnimatedNumber, Box, Section } from '../components';
import { Window } from '../layouts';
import { CargoCatalog } from './Cargo';
import { InterfaceLockNoticeBox } from './common/InterfaceLockNoticeBox';

export const SamaraCargo = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={780}
      height={750}>
      <Window.Content scrollable>
        <InterfaceLockNoticeBox
          accessText="a QM-level ID card" />
        {!data.locked && (
          <SamaraCargoContent />
        )}
      </Window.Content>
    </Window>
  );
};

const SamaraCargoContent = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <Section
        title="Cargo Express"
        buttons={(
          <Box inline bold>
            <AnimatedNumber
              value={Math.round(data.points)} />
            {' credits'}
          </Box>
        )} />
      <CargoCatalog express />
    </>
  );
};
